import sys
import logging

# Clear any existing logging handlers and configure logging to output only errors to stderr.
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)
logging.basicConfig(stream=sys.stderr, level=logging.ERROR)

import os
import asyncio
import io
from langchain_openai import ChatOpenAI
from browser_use import Agent, Browser, BrowserConfig
from dotenv import load_dotenv

load_dotenv()

# Get the instruction from the command-line arguments
if len(sys.argv) < 2:
    print("Usage: browser-use.py <instruction>")
    sys.exit(1)
instruction = sys.argv[1]

async def main():
    config = BrowserConfig(
        headless=True,
        disable_security=True
    )
    browser = Browser(config=config)
    
    agent = Agent(
        task=instruction,
        llm=ChatOpenAI(model="gpt-4o"),
        browser=browser
    )
    
    # Temporarily redirect stdout to a dummy buffer during agent.run()
    saved_stdout = sys.stdout
    sys.stdout = io.StringIO()
    history = await agent.run()
    _ = sys.stdout.getvalue()  # Discard any output produced during agent.run()
    sys.stdout = saved_stdout
    
    # Process the final result: split into lines, take the last non-empty line as the final answer
    final_result_raw = history.final_result()
    lines = [line for line in final_result_raw.strip().splitlines() if line.strip()]
    if lines:
        final_answer = lines[-1]          # Last non-empty line is the final answer
        reasoning = "\n".join(lines[:-1])   # All preceding lines are the reasoning
    else:
        final_answer = ""
        reasoning = ""
    
    # Print only the final answer to stdout (n8n will capture this)
    print(final_answer)
    # Print the reasoning to stderr for debugging purposes
    print(reasoning, file=sys.stderr)
    
    await browser.close()

asyncio.run(main())
