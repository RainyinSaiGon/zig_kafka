# zig-kafka

A distributed message queue built from scratch in Zig. Designed for high performance and educational exploration of distributed systems.

## Features

- **Custom Binary Protocol:** Lightweight, length-prefixed TCP messaging for fast serialization and safe data boundaries.
- **Distributed Architecture:** Clear separation of concerns with dedicated `Admin` (Broker), `Producer`, and `Consumer` nodes.
- **Asynchronous I/O:** Leverages Linux `io_uring` (via `std.os.linux.IoUring`) for high-throughput, completion-based non-blocking network operations.
- **Topic & Group Management:** Built-in support for message routing via topics and consumer group isolation.

## Prerequisites

- **Zig:** `0.15.2`
- **Environment:** A Linux environment (or WSL on Windows) is required to utilize the `io_uring` async I/O capabilities.

## Getting Started

Clone the repository and build the project from the `main` branch:

```bash
git clone -b main [https://github.com/RainyinSaigon/zig-kafka.git](https://github.com/RainyinSaigon/zig-kafka.git)
cd zig-kafka
zig build
