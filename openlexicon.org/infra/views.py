import json

from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.http import require_GET, require_POST

from . import services


@require_GET
def index(request):
    return render(request, "infra_query/index.html")


@require_POST
def query(request):
    """Reçoit {"items": "mot1 mot2 ...", "options": ["neighbors"]} et renvoie le tableau."""
    try:
        payload = json.loads(request.body or b"{}")
    except ValueError:
        return JsonResponse({"error": "Requête invalide."}, status=400)
    try:
        result = services.run_query(payload.get("items", ""), payload.get("options", []))
    except services.InfraError as exc:
        return JsonResponse({"error": str(exc)}, status=400)
    return JsonResponse(result)
