# argocd-test

https://argocd-image-updater.readthedocs.io/en/stable/basics/update-methods/#specifying-git-credentials
```
kubectl -n argocd-image-updater create secret generic git-creds \
  --from-literal=username=someuser \
  --from-literal=password=somepassword
```

contents read and write permissions

Settings>Actions>General>Workflow permissions  
Select `Read and write permissions`  
Check `Allow GitHub Actions to create and approve pull requests`  
