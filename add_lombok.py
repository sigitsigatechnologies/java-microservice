import os
import re

directories = [
    "auth-service",
    "user-service",
    "account-service",
    "transfer-service",
    "payroll-service",
    "transaction-service",
    "notification-service",
]

lombok_dep = """
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<optional>true</optional>
		</dependency>
"""

for d in directories:
    filepath = os.path.join(d, "pom.xml")
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
            
        if 'lombok' not in content:
            # add just before </dependencies>
            content = content.replace('</dependencies>', lombok_dep + '\t</dependencies>')
            
            with open(filepath, 'w') as f:
                f.write(content)
            print(f"Added lombok to {filepath}")

