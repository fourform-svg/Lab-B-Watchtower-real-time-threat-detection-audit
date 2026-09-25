import json
def lambda_handler(event, context):
    print(json.dumps(event))
    sev = event.get('detail',{}).get('severity',0)
    return {'alert':'HIGH' if sev>=7 else 'LOW', 'event':event}
