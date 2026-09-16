import { useState } from "react";
// Importado do SUBMÓDULO (design-system-components) montado em src/components/shared
import {
  Button,
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "./components/shared";

const stats = [
  { label: "Vendas hoje", value: "R$ 12.480", hint: "+8% vs ontem" },
  { label: "Pedidos", value: "312", hint: "+24 novos" },
  { label: "Visitantes", value: "8.940", hint: "tempo real" },
];

export function Dashboard() {
  const [likes, setLikes] = useState(0);

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="mx-auto max-w-5xl px-6 py-4 flex items-center justify-between">
          <div>
            <h1 className="text-lg font-bold tracking-tight">
              Sistema Principal
            </h1>
            <p className="text-xs text-muted-foreground">
              Consumindo o design system via Git submodule
            </p>
          </div>
          <Button variant="outline" size="sm">
            Meu perfil
          </Button>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-8 space-y-8">
        <section className="grid gap-4 sm:grid-cols-3">
          {stats.map((s) => (
            <Card key={s.label}>
              <CardHeader>
                <CardDescription>{s.label}</CardDescription>
                <CardTitle className="text-2xl">{s.value}</CardTitle>
              </CardHeader>
              <CardContent>
                <span className="text-xs text-muted-foreground">{s.hint}</span>
              </CardContent>
            </Card>
          ))}
        </section>

        <Card>
          <CardHeader>
            <CardTitle>Componente interativo</CardTitle>
            <CardDescription>
              Estado de clique controlado pelo consumidor, estilo vindo do
              submódulo.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-wrap items-center gap-3">
            <Button onClick={() => setLikes((n) => n + 1)}>
              👍 Curtir ({likes})
            </Button>
            <Button variant="secondary">Compartilhar</Button>
            <Button variant="ghost">Detalhes</Button>
          </CardContent>
          <CardFooter>
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setLikes(0)}
            >
              Zerar
            </Button>
          </CardFooter>
        </Card>
      </main>
    </div>
  );
}
