package com.cms.payroll.service;

import com.cms.payroll.client.AccountClient;
import com.cms.payroll.dto.PayrollEvent;
import com.cms.payroll.entity.Payroll;
import com.cms.payroll.entity.PayrollEmployee;
import com.cms.payroll.repository.PayrollRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
public class PayrollService {

    @Autowired
    private PayrollRepository repository;

    @Autowired
    private AccountClient accountClient;

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    private static final String TRANSFER_TOPIC = "transfer-events";

    @Transactional
    public Payroll processPayroll(Payroll payroll) {
        payroll.setTimestamp(LocalDateTime.now());
        
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (PayrollEmployee employee : payroll.getEmployees()) {
            totalAmount = totalAmount.add(employee.getAmount());
            employee.setPayroll(payroll);
        }
        payroll.setTotalAmount(totalAmount);

        boolean hasBalance = accountClient.validateBalance(payroll.getCompanyAccount(), totalAmount);
        
        if (!hasBalance) {
            payroll.setStatus("FAILED: INSUFFICIENT FUNDS");
            return repository.save(payroll);
        }

        accountClient.updateBalance(payroll.getCompanyAccount(), totalAmount.negate());
        for (PayrollEmployee employee : payroll.getEmployees()) {
            accountClient.updateBalance(employee.getEmployeeAccount(), employee.getAmount());

            PayrollEvent event = new PayrollEvent();
            event.setSourceAccount(payroll.getCompanyAccount());
            event.setDestinationAccount(employee.getEmployeeAccount());
            event.setAmount(employee.getAmount());
            event.setTimestamp(payroll.getTimestamp());

            kafkaTemplate.send(TRANSFER_TOPIC, event);
        }

        payroll.setStatus("SUCCESS");
        return repository.save(payroll);
    }
}
