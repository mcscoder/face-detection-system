from fastapi import APIRouter

from app.api.routes import auth, config, events, faces, people, recognitions, server, user

api_router = APIRouter()
api_router.include_router(server.router, tags=["server"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(config.router, prefix="/config", tags=["config"])
api_router.include_router(people.router, prefix="/people", tags=["people"])
api_router.include_router(faces.router, prefix="/faces", tags=["faces"])
api_router.include_router(recognitions.router, prefix="/recognitions", tags=["recognitions"])
api_router.include_router(user.router, prefix="/user", tags=["user"])
api_router.include_router(events.router, prefix="/events", tags=["events"])
