package hello;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.*;

@RestController
public class GreetingController {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/")
    public String home() {
        return "Spring Boot App is  Running";
    }

    @GetMapping("/greeting")
    public String greeting() {
        return "Hello from DevOps pipeline";
    }

    @GetMapping("/sayhi")
    public Greeting sayHi(@RequestParam(value = "name", defaultValue = "World") String name) {
        return new Greeting(counter.incrementAndGet(),
                String.format(template, name));
    }
}
