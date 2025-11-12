# OpenCode with NRP AI Setup Guide

This dotfiles repository includes configuration for OpenCode AI with NRP (National Research Platform) AI models.

## What's Included

- **OpenCode AI**: Advanced AI coding assistant
- **NRP AI Provider Configuration**: Pre-configured access to NRP's LLM endpoints
- **Available Models**: Qwen3, Gemma3, GLM-4.5V, and more

## Installation

The OpenCode installation is included in the main dotfiles installation:

```bash
./install.sh
```

Or install OpenCode separately:

```bash
./scripts/install-opencode.sh
```

## Configuration

### 1. Get NRP API Token

1. Visit the [NRP LLM token page](https://nrp-nautilus.io/)
2. Generate an API token
3. You must be a member of a group with LLM flag enabled

### 2. Set Environment Variable

Add your NRP API token to your environment:

```bash
export NRP_API_KEY="your-token-here"
```

To make this permanent, add it to your shell configuration:

```bash
echo 'export NRP_API_KEY="your-token-here"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Configure OpenCode

The installation automatically copies `opencode.json` to your project directory if it doesn't exist. This file configures the NRP AI provider with the following models:

- **Qwen3** - Multimodal model
- **Gemma3** - Multimodal model
- **GLM-4.5V** - Multimodal model
- **Embed Mistral** - Embedding model
- **Gorilla** - Evaluation model
- **Test Gaudi3** - Evaluation model
- **OLMo** - Evaluation model
- **Watt** - Evaluation model

## Usage

1. **Authentication**: Run `opencode auth login` to set up credentials
2. **Start Coding**: Use `opencode` in any project directory
3. **Select Provider**: Choose "NRP AI" from the provider list
4. **Select Model**: Pick from the available NRP models

## Configuration File

The `opencode.json` configuration uses the OpenAI-compatible endpoint:

```json
{
  "provider": {
    "nrp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "NRP AI",
      "options": {
        "baseURL": "https://ellm.nrp-nautilus.io/v1",
        "apiKey": "{env:NRP_API_KEY}"
      },
      "models": {
        "qwen3": {
          "name": "Qwen 3 (Multimodal)"
        }
        // ... other models
      }
    }
  }
}
```

## Troubleshooting

### Token Issues
- Ensure you're a member of a group with LLM access
- Verify your token is correctly set in the `NRP_API_KEY` environment variable
- Check token permissions on the NRP platform

### Configuration Issues
- Make sure `opencode.json` exists in your project directory
- Verify the configuration format matches the OpenCode schema
- Check that the NRP AI provider appears in OpenCode's provider list

### Model Access
- Some models may have usage restrictions
- Do not specify max output tokens (handled by NRP)
- Models have varying context window sizes

## Additional Resources

- [OpenCode Documentation](https://opencode.ai/docs)
- [NRP AI Documentation](https://nrp.ai/documentation/userdocs/ai/llm-managed/)
- [NRP LLM Token Page](https://nrp-nautilus.io/)