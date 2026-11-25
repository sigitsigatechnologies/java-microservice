package com.cms.user.controller;

import com.cms.user.entity.UserProfile;
import com.cms.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService service;

    @PostMapping
    public UserProfile createUser(@RequestBody UserProfile user) {
        return service.saveUser(user);
    }

    @GetMapping
    public List<UserProfile> getAllUsers() {
        return service.getAllUsers();
    }

    @GetMapping("/{username}")
    public UserProfile getUserByUsername(@PathVariable String username) {
        return service.getUserByUsername(username);
    }
}
