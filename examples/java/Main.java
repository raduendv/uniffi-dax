import com.amazon.dax.DaxConfig;
import com.amazon.dax.UniffiDax; 

public class Main {
    public static void main(String[] args) {
        // 1. Resolve the asynchronous future using .join()
        DaxConfig config = UniffiDax.loadFromEnv().join();

        // 2. Use the correct getter name formatting (without 'get')
        System.out.println("App Name: " + config.appName());
        System.out.println("Region: " + config.region());
    }
}
