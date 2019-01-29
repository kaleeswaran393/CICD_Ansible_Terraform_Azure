package hello;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

public class GreetingControllerJunitTest {


    GreetingController greetingController = new GreetingController();


    @Test
    public void shouldGreetings() {
        greetingController.greeting("DellEMC");
    }

}
