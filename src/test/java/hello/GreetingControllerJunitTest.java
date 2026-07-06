package hello;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(GreetingController.class)
public class GreetingControllerJunitTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void shouldGreetings() throws Exception {

        mockMvc.perform(get("/sayhi?name=DellEMC"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.content").value("Hello, DellEMC!"));
    }
}
