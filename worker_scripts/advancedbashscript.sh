#!/bin/bash

# Script to analyze system logs and generate a summary report

# Configuration
LOG_DIR="/var/log"
SYSLOG="${LOG_DIR}/syslog"
AUTHLOG="${LOG_DIR}/auth.log"
REPORT_FILE="/tmp/log_analysis_report.txt"
ERROR_LOG="/tmp/log_analysis_error.log"

# Function to initialize the report and error log
initialize_logs() {
    echo "Log Analysis Report - $(date)" > "$REPORT_FILE"
    echo "Error Log - $(date)" > "$ERROR_LOG"
}

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred while executing command: $1" >> "$ERROR_LOG"
        exit 1
    fi
}

# Function to analyze syslog
analyze_syslog() {
    echo "Analyzing syslog..." >> "$REPORT_FILE"
    grep "error" "$SYSLOG" | awk '{print $1, $2, $3, $5}' >> "$REPORT_FILE"
    check_error "analyzing syslog"
}

# Function to analyze auth.log
analyze_authlog() {
    echo "Analyzing auth.log..." >> "$REPORT_FILE"
    grep "Failed password" "$AUTHLOG" | awk '{print $1, $2, $3, $11}' >> "$REPORT_FILE"
    check_error "analyzing auth.log"
}

# Function to generate the final report
generate_report() {
    echo "Analysis complete. Report generated at $REPORT_FILE" | tee -a "$REPORT_FILE"
}

# Error handling
trap 'echo "Script interrupted." >> "$ERROR_LOG"; exit 1;' INT TERM

# Main script execution
initialize_logs
analyze_syslog
analyze_authlog
generate_report

exit 0

