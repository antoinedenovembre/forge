# forge-cpp
Create-react-app for modern C++.

## Quickstart
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -e .
forge new demo && cd demo
cmake -S . -B build && cmake --build build -j && ./build/demo
```