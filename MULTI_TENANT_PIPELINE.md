# Multi-Tenant Bitbucket Pipeline - Implementation Guide

## Overview

This document outlines a comprehensive Bitbucket Pipeline architecture for deploying Terraform code across **20 customers**, each with **separate AWS accounts** and **multiple environments** (DEV, QA, UAT, PREPROD, PROD).

## Key Objectives

 **Precise Customer Control**: Each customer has isolated deployments with separate AWS accounts  
 **Multi-Environment Support**: DEV, QA, UAT, PREPROD, PROD for each customer  
 **Security & Governance**: OIDC-based authentication, state locking, compliance checks  
 **Cost Optimization**: Pre-deployment cost estimation  
 **Complete Audit Trail**: All deployments logged and reviewable  

## Architecture

Custom pipelines: 100 total (20 customers  5 environments)
- Customer-1 through Customer-20
- Each with DEV, QA, UAT, PREPROD, PROD pipelines
- State management: customer/environment/terraform.tfstate
- Security: OIDC-based AWS authentication
- Approval gates: Manual approval before apply/destroy

## Bitbucket Pipeline Configuration

See PIPELINE_CONFIGURATION.md for detailed YAML setup and IAM policies.
