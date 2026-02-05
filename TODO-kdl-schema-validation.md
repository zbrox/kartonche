# TODO: Implement KDL Schema Validation

## Goal
Add proper schema validation using Merchants/schema.kdl to validate merchants.kdl

## Options
1. Use mise to install kdl-rs (Rust implementation) if it has schema validation
2. Find/install existing KDL schema validator tool
3. Implement schema validation in Swift generator

## Current Status
- schema.kdl exists and documents the structure
- Validation only checks KDL syntax and required fields
- Does not validate against formal schema

## Files to Update
- Scripts/generate-merchants/Sources/main.swift (add schema validation)
- .mise/tasks/validate-merchants (use schema validator)

