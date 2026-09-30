import com.amazon.dax.add
import com.amazon.dax.loadFromEnv
import com.amazon.dax.sdkConfigRegion

suspend fun main() {
    val result = add(2uL, 3uL)
    println("2 + 3 = $result")

    val config = loadFromEnv()
    try {
        println("region: ${config.region ?: "<not set>"}")
    } finally {
    }
}
