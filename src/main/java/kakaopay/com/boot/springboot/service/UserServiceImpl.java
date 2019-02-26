package kakaopay.com.boot.springboot.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kakaopay.com.boot.springboot.domain.User;
import kakaopay.com.boot.springboot.domain.UserRepository;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    UserRepository repository;
    
    @Override
    public Optional<User> findById(Long id) {
        return repository.findById(id);
    }
}
