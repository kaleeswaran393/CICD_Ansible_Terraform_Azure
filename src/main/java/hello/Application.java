package hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.system.ApplicationPidFileWriter;

@SpringBootApplication
public class Application {

    public static void main(String[] args) {

        SpringApplicationBuilder app = new SpringApplicationBuilder(Application.class).web(true);
        app.build().addListeners(new ApplicationPidFileWriter("./bin/shutdown.pid"));
        app.run();
    }
}
