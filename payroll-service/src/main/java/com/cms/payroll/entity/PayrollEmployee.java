package com.cms.payroll.entity;
import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Data
public class PayrollEmployee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String employeeAccount;
    private BigDecimal amount;

    @ManyToOne
    @JoinColumn(name = "payroll_id")
    @JsonIgnore
    private Payroll payroll;
}
