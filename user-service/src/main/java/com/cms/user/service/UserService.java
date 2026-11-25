package com.cms.user.service;

import com.cms.user.entity.UserProfile;
import com.cms.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository repository;

    public UserProfile saveUser(UserProfile user) {
        return repository.save(user);
    }

    public List<UserProfile> getAllUsers() {
        return repository.findAll();
    }

    public UserProfile getUserByUsername(String username) {
        return repository.findByUsername(username).orElseThrow(() -> new RuntimeException("User not found"));
    }
}
