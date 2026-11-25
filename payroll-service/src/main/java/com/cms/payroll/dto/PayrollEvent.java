package com.cms.payroll.dto;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PayrollEvent {
    private String sourceAccount;
    private String destinationAccount;
    private BigDecimal amount;
    private LocalDateTime timestamp;
}
