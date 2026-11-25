package com.cms.transfer.service;

import com.cms.transfer.client.AccountClient;
import com.cms.transfer.dto.TransferEvent;
import com.cms.transfer.entity.Transfer;
import com.cms.transfer.repository.TransferRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class TransferService {

    @Autowired
    private TransferRepository repository;

    @Autowired
    private AccountClient accountClient;

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    private static final String TRANSFER_TOPIC = "transfer-events";

    @Transactional
    public Transfer initiateTransfer(Transfer transfer) {
        transfer.setTimestamp(LocalDateTime.now());
        
        // 1. Validate Balance synchronously using Feign
        boolean hasBalance = accountClient.validateBalance(transfer.getSourceAccount(), transfer.getAmount());
        
        if (!hasBalance) {
            transfer.setStatus("FAILED: INSUFFICIENT FUNDS");
            return repository.save(transfer);
        }

        // 2. Update balances (Deduct from source, add to destination)
        accountClient.updateBalance(transfer.getSourceAccount(), transfer.getAmount().negate());
        accountClient.updateBalance(transfer.getDestinationAccount(), transfer.getAmount());

        transfer.setStatus("SUCCESS");
        Transfer savedTransfer = repository.save(transfer);

        // 3. Send event to Kafka for transaction history and notifications
        TransferEvent event = new TransferEvent();
        event.setSourceAccount(transfer.getSourceAccount());
        event.setDestinationAccount(transfer.getDestinationAccount());
        event.setAmount(transfer.getAmount());
        event.setTimestamp(transfer.getTimestamp());

        kafkaTemplate.send(TRANSFER_TOPIC, event);

        return savedTransfer;
    }
}
