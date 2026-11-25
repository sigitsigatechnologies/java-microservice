package com.cms.payroll.entity;
import lombok.Data;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
public class Payroll {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String companyAccount;
    private BigDecimal totalAmount;
    private String status;
    private LocalDateTime timestamp;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "payroll")
    private List<PayrollEmployee> employees;
}
