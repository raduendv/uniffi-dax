package main

import (
	"fmt"

	uniffi "example.com/uniffi-dax/uniffi_dax"
	"github.com/davecgh/go-spew/spew"
)

func main() {
	result := uniffi.Add(2, 3)
	fmt.Printf("2 + 3 = %d\n", result)

	config := uniffi.LoadFromEnv()
	defer config.Destroy()
	region := uniffi.SdkConfigRegion(config)
	if region == nil {
		fmt.Println("region: <not set>")
	} else {
		fmt.Printf("region: %s\n", *region)
	}

	spew.Dump(config)
	if config.Region != nil {
		spew.Dump(*config.Region)
	}
}
