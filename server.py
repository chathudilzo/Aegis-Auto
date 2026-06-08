import asyncio
import json
import random
import websockets

car_state = {
    "rpm": 1000,
    "speed": 0,
    "engine_temp": 85.0,
    "tire_pressure": {"fl": 32, "fr": 32, "rl": 32, "rr": 32},
    "fuel_level": 100,
    "brake_temp": {"fl": 95, "fr": 95, "rl": 80, "rr": 80},
    "suspension": {"fl": 45, "fr": 45, "rl": 52, "rr": 52},
    "battery_soh": 98,
    "dtcs": []
}

acceleration_phase = True


def simulate_engine_physics():
    global acceleration_phase

    if acceleration_phase:
        # REALISTIC ACCEL: Gain 40 to 75 RPM per 50ms (takes ~4 seconds to redline)
        car_state["rpm"] += random.randint(40, 75)

        # Engine heats up slowly under load
        car_state["engine_temp"] += random.uniform(0.02, 0.08)

        # Brakes cool down slowly while driving
        for key in car_state["brake_temp"]:
            car_state["brake_temp"][key] = max(
                70, car_state["brake_temp"][key] - random.randint(0, 1))

        # Suspension shifts rearward smoothly under launch
        car_state["suspension"]["fl"] = max(
            35, car_state["suspension"]["fl"] - 1)
        car_state["suspension"]["fr"] = max(
            35, car_state["suspension"]["fr"] - 1)
        car_state["suspension"]["rl"] = min(
            65, car_state["suspension"]["rl"] + 1)
        car_state["suspension"]["rr"] = min(
            65, car_state["suspension"]["rr"] + 1)

        if car_state["rpm"] >= 7500:
            acceleration_phase = False
    else:
        # REALISTIC BRAKING: Lose 120 to 160 RPM per 50ms (takes ~2 seconds to stop)
        car_state["rpm"] -= random.randint(120, 160)

        # Engine cools down slightly off-throttle
        car_state["engine_temp"] -= random.uniform(0.05, 0.1)

        # Brakes heat up realistically under friction
        car_state["brake_temp"]["fl"] = min(
            450, car_state["brake_temp"]["fl"] + random.randint(4, 8))
        car_state["brake_temp"]["fr"] = min(
            450, car_state["brake_temp"]["fr"] + random.randint(4, 8))
        car_state["brake_temp"]["rl"] = min(
            350, car_state["brake_temp"]["rl"] + random.randint(2, 5))
        car_state["brake_temp"]["rr"] = min(
            350, car_state["brake_temp"]["rr"] + random.randint(2, 5))

        # Suspension dives forward heavily under braking
        car_state["suspension"]["fl"] = min(
            75, car_state["suspension"]["fl"] + 2)
        car_state["suspension"]["fr"] = min(
            75, car_state["suspension"]["fr"] + 2)
        car_state["suspension"]["rl"] = max(
            35, car_state["suspension"]["rl"] - 2)
        car_state["suspension"]["rr"] = max(
            35, car_state["suspension"]["rr"] - 2)

        # Trigger fault if brakes melt
        if car_state["brake_temp"]["fl"] > 400:
            car_state["dtcs"] = ["B0028-13"]
        else:
            car_state["dtcs"] = []

        if car_state["rpm"] <= 1200:
            acceleration_phase = True

    # Enforce hard limits
    car_state["rpm"] = max(800, min(7600, car_state["rpm"]))
    car_state["engine_temp"] = round(
        max(80.0, min(115.0, car_state["engine_temp"])), 1)

    # Calculate speed based on gear ratios (RPM / 22 roughly equals km/h in top gear)
    car_state["speed"] = int(car_state["rpm"] / 22)


async def handler(websocket):
    print("App connected to Digital Twin Engine.")
    try:
        while True:
            simulate_engine_physics()
            await websocket.send(json.dumps(car_state))
            await asyncio.sleep(0.05)
    except websockets.ConnectionClosed:
        print("App disconnected.")


async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765):
        print("Aegis Telemetry Core running on port 8765")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
