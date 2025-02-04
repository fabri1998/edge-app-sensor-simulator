local json = require("json")
local config_file = io.open("config.json", "r")

if not config_file then
    print("Could not open config.json")
    return
end

-- Reading the configuration.
local config_content = config_file:read("*a")
config_file:close()
local cfg = json.decode(config_content)

-- MQTT-settings
local topic_prefix = "iotopen/simulated/"
local mq = require("mq")
local timer = require("timer")

-- Function for generating fake data.
local function generate_fake_data(sensor_type)
    if sensor_type == "Vibration Sensor" then
        return { vibration = math.random(0, 100) / 10 }
    elseif sensor_type == "Multi-Sensor" then
        return { temperature = math.random(-10, 40), humidity = math.random(0, 100) }
    elseif sensor_type == "Temperature Sensor" then
        return { temperature = math.random(-20, 50) }
    elseif sensor_type == "Noise Sensor" then
        return { noise_level = math.random(30, 120) }
    elseif sensor_type == "Presence Sensor" then
        return { presence = math.random(0, 1) == 1 }
    elseif sensor_type == "Tracking/Positioning Sensor" then
        return { latitude = 59.0 + math.random() * 0.1, longitude = 18.0 + math.random() * 0.1 }
    else
        return { message = "Unknown sensor type" }
    end
end

-- Main loop: Generate and send data.
local function send_fake_data()
    for _, sensor in ipairs(cfg.config.sensor_types) do
        local data = generate_fake_data(sensor)
        local topic = topic_prefix .. sensor:gsub(" ", "_"):lower()
        local payload = json.encode(data)

        mq:pub(topic, payload)
        print("Published to:", topic, "Data:", payload)
    end

    timer:after(cfg.config.update_interval, send_fake_data)
end

local function onStart()
    print("Starting simulated sensors...")
    send_fake_data()
end

onStart()
