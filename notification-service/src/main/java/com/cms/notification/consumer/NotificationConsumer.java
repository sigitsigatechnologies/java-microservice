package com.cms.notification.consumer;

import com.cms.notification.dto.TransferEvent;
import com.cms.notification.entity.NotificationLog;
import com.cms.notification.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class NotificationConsumer {

    @Autowired
    private NotificationRepository repository;

    @KafkaListener(topics = "transfer-events", groupId = "notification-group")
    public void consumeTransferEvent(TransferEvent event) {
        String message = String.format("Transfer of %s from %s to %s successfully completed at %s.", 
                event.getAmount(), event.getSourceAccount(), event.getDestinationAccount(), event.getTimestamp());
        
        NotificationLog log = new NotificationLog();
        log.setRecipientAccount(event.getDestinationAccount()); // Notify destination
        log.setMessage(message);
        log.setTimestamp(LocalDateTime.now());
        
        repository.save(log);
        System.out.println("Notification sent: " + message);
    }
}
