# Databricks Asset Bundle for Notebooks

This project contains Databricks notebooks that are deployed using Databricks Asset Bundles. The project has been streamlined to focus solely on notebook development and deployment, removing all Python package-related components.

## Project Structure

```
.
├── .github/workflows/       # GitHub Actions workflows for CI/CD
├── resources/               # Databricks Asset Bundle resources (job configurations)
└── src/                     # Source notebooks
```

## Branching Strategy

This project follows a three-branch deployment strategy:

- `dev`: Development branch for active development
- `qa`: Quality Assurance branch for testing
- `prd`: Production branch for final deployment

## CI/CD Pipeline

The GitHub Actions workflows automate the following:

1. **Dev to QA**: When a PR is opened from `dev` to `qa`, the workflow:
   - Validates the bundle format
   - Deploys to the QA environment

2. **QA to PRD**: When a PR is opened from `qa` to `prd`, the workflow:
   - Validates that the source branch is `qa`
   - Validates the bundle format
   
3. **Deploy to PRD**: When code is merged to the `prd` branch, the workflow:
   - Deploys the bundle to the production environment
   - Verifies the deployment

## Local Development

To get started with local development:

1. Install the Databricks CLI:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
   ```

2. Configure your Databricks workspace connection:
   ```bash
   databricks configure
   ```

3. Validate and deploy the bundle to your development environment:
   ```bash
   databricks bundle validate
   databricks bundle deploy
   ```

## Adding New Notebooks

To add a new notebook:

1. Create a new notebook file in the `src/` directory
2. Update the job configuration in `resources/` if needed
3. Deploy and test on your development environment
