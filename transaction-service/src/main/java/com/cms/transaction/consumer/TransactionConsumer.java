package com.cms.transaction.consumer;

import com.cms.transaction.dto.TransferEvent;
import com.cms.transaction.entity.TransactionHistory;
import com.cms.transaction.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class TransactionConsumer {

    @Autowired
    private TransactionRepository repository;

    @KafkaListener(topics = "transfer-events", groupId = "transaction-group")
    public void consumeTransferEvent(TransferEvent event) {
        TransactionHistory history = new TransactionHistory();
        history.setSourceAccount(event.getSourceAccount());
        history.setDestinationAccount(event.getDestinationAccount());
        history.setAmount(event.getAmount());
        history.setTimestamp(event.getTimestamp());

        repository.save(history);
        System.out.println("Transaction history recorded: " + history.getId());
    }
}
