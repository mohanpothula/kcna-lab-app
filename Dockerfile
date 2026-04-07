FROM python:3.12-slim
WORKDIR /app
RUN echo "print('Hello from KCNA Python Lab!')" > app.py
CMD ["python", "app.py"]
