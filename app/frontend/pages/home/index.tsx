type HomeProps = {
  message: string
}

export default function Home({ message }: HomeProps) {
  return (
    <main className="flex min-h-screen items-center justify-center">
      <h1 className="text-4xl font-bold">{message}</h1>
    </main>
  )
}
