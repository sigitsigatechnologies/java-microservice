import os
import re

directories = [
    "auth-service/src/main/java/com/cms/auth",
    "user-service/src/main/java/com/cms/user",
    "account-service/src/main/java/com/cms/account",
    "transfer-service/src/main/java/com/cms/transfer",
    "payroll-service/src/main/java/com/cms/payroll",
    "transaction-service/src/main/java/com/cms/transaction",
    "notification-service/src/main/java/com/cms/notification",
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # If it already has lombok, skip
    if 'lombok.Data' in content:
        return

    # Check if it has getters/setters
    if 'public String get' not in content and 'public Long get' not in content and 'public BigDecimal get' not in content and 'public void set' not in content and 'public LocalDateTime get' not in content and 'public List<PayrollEmployee> get' not in content and 'public Payroll get' not in content:
        return

    # Remove all getters and setters
    content = re.sub(r'\s*public\s+[\w<>]+\s+get\w+\(\)\s*{\s*return\s+\w+;\s*}', '', content)
    content = re.sub(r'\s*public\s+void\s+set\w+\([\w<>]+\s+\w+\)\s*{\s*this\.\w+\s*=\s*\w+;\s*}', '', content)
    # Also remove the "// Getters and Setters" comment if present
    content = re.sub(r'\s*// Getters and Setters', '', content)

    # Add @Data import and annotation
    lines = content.split('\n')
    package_idx = 0
    for i, line in enumerate(lines):
        if line.startswith('package '):
            package_idx = i
            break
            
    lines.insert(package_idx + 1, 'import lombok.Data;')
    
    # Find the class declaration and put @Data before it
    for i, line in enumerate(lines):
        if 'public class' in line:
            lines.insert(i, '@Data')
            break
            
    with open(filepath, 'w') as f:
        f.write('\n'.join(lines))
    print(f"Refactored {filepath}")

for d in directories:
    for root, dirs, files in os.walk(d):
        for f in files:
            if f.endswith('.java'):
                process_file(os.path.join(root, f))
