package com.cms.transaction.dto;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TransferEvent {
    private String sourceAccount;
    private String destinationAccount;
    private BigDecimal amount;
    private LocalDateTime timestamp;
}
