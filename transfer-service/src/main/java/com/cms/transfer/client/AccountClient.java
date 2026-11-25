package com.cms.transfer.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import java.math.BigDecimal;

@FeignClient(name = "account-service", url = "${account-service.url}")
public interface AccountClient {

    @GetMapping("/api/accounts/{accountNumber}/validate")
    boolean validateBalance(@PathVariable("accountNumber") String accountNumber, @RequestParam("amount") BigDecimal amount);

    @PostMapping("/api/accounts/{accountNumber}/update-balance")
    void updateBalance(@PathVariable("accountNumber") String accountNumber, @RequestParam("amount") BigDecimal amount);
}
