import asyncio
import json
import random
import websockets

car_state = {
    "rpm": 1000,
    "speed": 0,
    "engine_temp": 85.0,
    "tire_pressure": {"fl": 32, "fr": 32, "rl": 32, "rr": 32},
    "fuel_level": 100
}


def simulate_engine_physics():
    """Simulates real-world data drift."""
    car_state["rpm"] = max(
        800, min(7500, car_state["rpm"] + random.randint(-200, 200)))

    if car_state["rpm"] > 4000:
        car_state["engine_temp"] += 0.5
    else:
        car_state["engine_temp"] -= 0.1

    car_state["engine_temp"] = round(
        max(80, min(120, car_state["engine_temp"])), 1)

    car_state["speed"] = int(car_state["rpm"] / 150)


async def handler(websocket):
    """Sends telemetry data every 100ms."""
    print("App connected to Digital Twin.")
    try:
        while True:
            simulate_engine_physics()
            message = json.dumps(car_state)
            await websocket.send(message)
            await asyncio.sleep(0.1)
    except websockets.ConnectionClosed:
        print("App disconnected.")


async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765):
        print("Telemetry Server started on ws://localhost:8765")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
