use std::{borrow::Cow};
use aws_config::{AppName, Region};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DaxAppName(pub Cow<'static, str>);

uniffi::custom_type!(
    AppName,
    String,
    {
        remote,
        lower: |obj| obj.to_string(),
        try_lift: |val| {
            AppName::new(val)
                // map_err expects an anyhow::Error instance directly
                .map_err(|e| anyhow::anyhow!("Invalid AWS AppName: {}", e))
        },
    }
);

uniffi::custom_type!(
    DaxAppName,
    AppName,
    {
        lower: |obj| {
            AppName::new(obj.0.into_owned())
                .unwrap_or_else(|_| AppName::new("fallback-invalid-name").unwrap())
        },
        try_lift: |app_name| {
            Ok(DaxAppName(Cow::Owned(app_name.to_string())))
        },
    }
);


#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DaxRegion(pub Cow<'static, str>);

uniffi::custom_type!(
    Region,
    String,
    {
        remote,
        lower: |obj| obj.to_string(),
        try_lift: |val| Ok(Region::new(val)),
    }
);

uniffi::custom_type!(
    DaxRegion,
    Region,
    {
        lower: |obj| Region::new(obj.0.into_owned()),
        try_lift: |app_name| {
            Ok(DaxRegion(Cow::Owned(app_name.to_string())))
        },
    }
);

#[derive(uniffi::Record)]
pub struct DaxConfig {
    app_name: Option<AppName>,
    region: Option<Region>,
}

#[allow(deprecated)]
#[uniffi::export]
pub async fn load_from_env() -> DaxConfig {
    let cfg = aws_config::load_from_env().await;
    DaxConfig {
        app_name: cfg.app_name().cloned(),
        region: cfg.region().cloned(),
    }
}

#[uniffi::export]
pub fn sdk_config_region(_config: DaxConfig) -> Option<String> {
    // config.region().map(|region| region.as_ref().to_owned())
    Some("test".to_string())
}