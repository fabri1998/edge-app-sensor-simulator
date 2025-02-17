local json = require("cjson")
local copas = require("copas")

math.randomseed(os.time())

-- Läs konfigurationsfilen
local config_path = "/src/config.json"
local config_file = io.open(config_path, "r")

if not config_file then
    print("Could not open config.json at " .. config_path)
    return
end

local config_content = config_file:read("*a")
config_file:close()

local cfg, err = json.decode(config_content)
if not cfg then
    print("Error decoding JSON:", err)
    return
end

if not cfg.config or not cfg.config.sensor_types or not cfg.config.update_interval then
    print("Invalid configuration format in config.json")
    return
end

-- Funktion för att generera fakedata
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

-- Generera och skriv ut data
local function send_fake_data()
    while true do
        for _, sensor in ipairs(cfg.config.sensor_types) do
            local data = generate_fake_data(sensor)
            local payload = json.encode(data)

            print("Generated data for", sensor, ":", payload)
        end

        -- Använd `copas.sleep()` inuti en coroutine
        copas.sleep(cfg.config.update_interval)
    end
end

-- Starta simuleringen
local function onStart()
    print("Starting simulated sensors...")
    copas.addthread(send_fake_data)
    copas.loop() 
end

onStart()
