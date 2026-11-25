package com.cms.transaction.repository;

import com.cms.transaction.entity.TransactionHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionRepository extends JpaRepository<TransactionHistory, Long> {
}
