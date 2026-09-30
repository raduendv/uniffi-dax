import asyncio

import uniffi_dax


async def main():
    result = uniffi_dax.add(2, 3)
    print(f"2 + 3 = {result}")

    config = await uniffi_dax.load_from_env()
    print(f"region: {config.region or '<not set>'}")


asyncio.run(main())
