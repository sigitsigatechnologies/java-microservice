package com.cms.payroll.controller;

import com.cms.payroll.entity.Payroll;
import com.cms.payroll.service.PayrollService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payroll")
public class PayrollController {

    @Autowired
    private PayrollService service;

    @PostMapping
    public Payroll executePayroll(@RequestBody Payroll payroll) {
        return service.processPayroll(payroll);
    }
}
