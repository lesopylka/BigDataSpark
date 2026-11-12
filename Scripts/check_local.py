import csv,importlib.util,os,json
from pathlib import Path
from unittest.mock import patch
os.environ['SPARK_LOCAL_IP']='127.0.0.1'
from pyspark.sql import SparkSession
spark=SparkSession.builder.master('local[2]').appName('check-sales').config('spark.ui.enabled','false').config('spark.sql.shuffle.partitions','2').getOrCreate()
spark.sparkContext.setLogLevel('ERROR')
repo = Path(__file__).resolve().parents[1]
rows=[]
for path in (repo / 'data').glob('*.csv'):
 for row in csv.DictReader(path.open(newline='')):
  rows.append({'source_file':path.name,'sale_key':f"{path.name}:{row['id']}",**row})
source=spark.createDataFrame(rows)
spec=importlib.util.spec_from_file_location('etl',repo / 'Scripts/etl.py');etl=importlib.util.module_from_spec(spec);spec.loader.exec_module(etl)
tables={'public.mock_data':source};reports={}
def write(frame,name):
 tables[name]=frame.cache()
 count=frame.count()
 print(name,count,flush=True)
 if name=='star.fact_sales':
  assert count==10000
  assert frame.selectExpr('sum(sale_quantity)','sum(sale_total_price)').first()[0]==54623

def clickhouse(query,data=None):
 if query.startswith('INSERT'):
  table=query.split()[2];values=[json.loads(line) for line in data.decode().splitlines()];assert values
  reports[table]=values
class Connection:
 def __enter__(self):return self
 def __exit__(self,*args):return False
 def execute(self,*args):pass
os.chdir(repo)
with patch.object(etl,'read_table',lambda session,name:tables[name]),patch.object(etl,'write_table',write),patch.object(etl,'clickhouse',clickhouse),patch('psycopg.connect',lambda *a,**k:Connection()):
 etl.main()
assert len(reports)==6
assert abs(sum(r['value'] for r in reports['lab.report_products'] if r['metric']=='category_revenue')-2529852.12)<.01
print(json.dumps({k: len(v) for k, v in reports.items()}, indent=2))
print('Spark ETL: 10000 фактов, шесть витрин, контрольная выручка совпала')
