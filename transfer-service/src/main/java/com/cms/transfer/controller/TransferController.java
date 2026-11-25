package com.cms.transfer.controller;

import com.cms.transfer.entity.Transfer;
import com.cms.transfer.service.TransferService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transfers")
public class TransferController {

    @Autowired
    private TransferService service;

    @PostMapping
    public Transfer executeTransfer(@RequestBody Transfer transfer) {
        return service.initiateTransfer(transfer);
    }
}
