Title: Realtime Assistant
Tags: [multimodal, audio]

# Open AI realtime API with Chainlit

This cookbook demonstrates how to build realtime copilots with Chainlit.

## Key Features

- **Realtime Python Client**: Based off https://github.com/openai/openai-realtime-api-beta
- **Multimodal experience**: Speak and write to the assistant at the same time
- **Tool calling**: Ask the assistant to perform tasks and see their output in the UI
- **Visual Presence**: Visual cues indicating if the assistant is listening or speaking

## Quick Start

1. Set your `OPENAI_API_KEY` in the `.env` file
2. Run with Docker: `./run-docker.sh`
3. Or use Docker Compose: `docker compose up --build`

## Production Deployment

For production deployment without a reverse proxy:

```bash
./deploy-production.sh
```

**Note**: This deployment runs without SSL termination. For production use with SSL, consider:
- Nginx with Let's Encrypt
- Traefik
- Cloudflare Tunnel
- Or run behind a load balancer
