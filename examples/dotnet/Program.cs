using UniffiDax;

var result = UniffiDaxMethods.Add(2, 3);
Console.WriteLine($"2 + 3 = {result}");

var config = await UniffiDaxMethods.LoadFromEnv();
Console.WriteLine($"region: {config.Region}");
