package kakaopay.com.boot.springboot.service;

import java.util.Optional;

import kakaopay.com.boot.springboot.domain.User;

public interface UserService {

    Optional<User> findById(Long id);
}
