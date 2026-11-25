package com.cms.account.controller;

import com.cms.account.entity.Account;
import com.cms.account.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    @Autowired
    private AccountService service;

    @PostMapping
    public Account createAccount(@RequestBody Account account) {
        return service.createAccount(account);
    }

    @GetMapping("/{accountNumber}")
    public Account getAccount(@PathVariable String accountNumber) {
        return service.getAccount(accountNumber);
    }

    @PostMapping("/{accountNumber}/update-balance")
    public void updateBalance(@PathVariable String accountNumber, @RequestParam BigDecimal amount) {
        service.updateBalance(accountNumber, amount);
    }

    @GetMapping("/{accountNumber}/validate")
    public boolean validateBalance(@PathVariable String accountNumber, @RequestParam BigDecimal amount) {
        return service.validateBalance(accountNumber, amount);
    }
}
