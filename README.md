# argocd-test

https://argocd-image-updater.readthedocs.io/en/stable/basics/update-methods/#specifying-git-credentials
```
kubectl -n argocd-image-updater create secret generic git-creds \
  --from-literal=username=someuser \
  --from-literal=password=somepassword
```

contents read and write permissions
