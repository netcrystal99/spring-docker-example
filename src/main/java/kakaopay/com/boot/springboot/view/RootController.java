package kakaopay.com.boot.springboot.view;

import org.springframework.web.bind.annotation.GetMapping;

import kakaopay.com.boot.springboot.view.annotation.ViewController;

@ViewController
public class RootController {

    @GetMapping("/root")
    public String root() {
        return "root";
    }
}
