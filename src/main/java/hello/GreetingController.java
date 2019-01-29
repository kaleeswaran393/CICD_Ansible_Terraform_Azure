package hello;


import java.util.concurrent.atomic.AtomicLong;

import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

    private static final String template = "Hello, %s!";
    public long counter=100;


    @RequestMapping("/sayhi")
    public Greeting greeting(@RequestParam(value="name", defaultValue="World") String name) {
        return new Greeting(counter++, String.format(template, name));
    }


    @Bean
    public AtomicLong getAtomicLong(){
        return  new AtomicLong();
    }
}
