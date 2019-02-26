package kakaopay.com.boot.springboot.view;

import org.springframework.web.bind.annotation.GetMapping;

import kakaopay.com.boot.springboot.view.annotation.ViewController;

@ViewController
public class ErrorViewController {

	@GetMapping("/occurred-error")
	public String occurError() {
		throw new RuntimeException("에러야 일어나라!!!");
	}
}
