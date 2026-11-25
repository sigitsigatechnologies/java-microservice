package com.cms.account.service;

import com.cms.account.entity.Account;
import com.cms.account.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class AccountService {

    @Autowired
    private AccountRepository repository;

    public Account createAccount(Account account) {
        return repository.save(account);
    }

    public Account getAccount(String accountNumber) {
        return repository.findByAccountNumber(accountNumber).orElseThrow(() -> new RuntimeException("Account not found"));
    }

    @Transactional
    public void updateBalance(String accountNumber, BigDecimal amount) {
        Account account = getAccount(accountNumber);
        account.setBalance(account.getBalance().add(amount));
        repository.save(account);
    }

    public boolean validateBalance(String accountNumber, BigDecimal amount) {
        Account account = getAccount(accountNumber);
        return account.getBalance().compareTo(amount) >= 0;
    }
}
