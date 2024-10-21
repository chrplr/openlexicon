from django.contrib.auth import get_user_model
from openlexicon.prod_base_settings import su_pwd
UserModel = get_user_model()

su=UserModel.objects.create_user("jessica.bourgin@univ-smb.fr", password=su_pwd)
su.is_superuser=True
su.is_staff=True
su.save()
